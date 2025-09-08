classdef model_exp_environement_multi_PPF < rl.env.MATLABEnvironment
    %MYENVIRONMENT: Template for defining custom environment in MATLAB.    
    
    %% Properties (set properties' attributes accordingly)
    properties
                     
        % Sample time
        time
        Ts 
        
        Sys_mimo
        sys_fb
        Hd
        H

        K_value
        Xi_value
        Ome_value
        
        sig_disturb
        
        y1_ddot_ref
        y2_ddot_ref
        y3_ddot_ref

        rms_y1_ddot_ref
        rms_y2_ddot_ref
        rms_y3_ddot_ref

        y1_ddot
        y2_ddot
        y3_ddot

        rms_y1_ddot
        rms_y2_ddot
        rms_y3_ddot

        rwd_type
        rwd_coef

        outofrange

        Rmin
        Rmax
        norm

        Gm
        Pm
    end
    
    properties
        % Initialize system state [y1,y2]'
        State = zeros(3,1)
         
    end

    properties (Transient,Access = private)
        Visualizer = []
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    % Handle to figure
        Figure

    end
%     methods (Abstract,Access = protected)
%         Rvalue = getRvalue(this,action)
%         
%         Reward = getReward(this,x,force)
%     end 

    %% Necessary Methods
    methods             

        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = model_exp_environement_multi_PPF(ObservationInfo, ActionInfo, dt, time_input, Disturbance, Sys, reward_type,rwd_coef)
                      
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo)
            
            % Initialize property values and pre-compute necessary values
            %updateActionInfo(this);
            this.Ts=dt;

            this.time=time_input;

            this.Sys_mimo=Sys;   
            
            this.sig_disturb=Disturbance;

            fprintf('init env done'); 
            this.rwd_type=reward_type;
            this.outofrange=0;
            this.rwd_coef=rwd_coef;

            this.Rmin=-15;
            this.Rmax=15;

        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            
            Action'
            LoggedSignals = [];
            s = tf([1 0],[1]);

            % Get action 
            if sum(isnan(Action))>0 
                Action=zeros(1,9);
            end              

            this.K_value = -10.^((Action(1:3)./10./2+1/2)*10);%=-10.^(10*[Action(1:3)])+1;
            this.Xi_value =[Action(4:6)./10./2+1/2];%*1000*2*pi;
            this.Ome_value =[Action(7:9)./10./2+1/2]*1000*2*pi;

            %Normalisaton des entrées

%             if Action(1)<-1 this.K_value(1)=0; end
%             if Action(2)<-1 this.K_value(2)=0; end
%             if Action(3)<-1 this.K_value(3)=0; end
            
%             this.K_value =-10.^(10*[Action(1:3)./2+1/2])+1;
%             this.Xi_value =[Action(4:6)./2+1/2];%*1000*2*pi;
%             this.Ome_value =[Action(7:9)./2+1/2]*1000*2*pi;
            
                      
            %TO DO long Term: créer un fonction control law avec action
            %comme entrée avec différentes lois de controle possibles

            %Define control law 
            for i=1:3
                Crtl(i)=this.K_value(i)*1/(s^2+2*this.Xi_value(i)*this.Ome_value(i)*s+this.Ome_value(i)^2);
            end

            this.H=[Crtl(1) 0       0;
                    0      Crtl(2)  0;
                    0      0       Crtl(3)];

            
            %Compute feedback system
            feedin=[1 2 3];
            feedout=[1 2 3];
            this.sys_fb=feedback(this.Sys_mimo,this.H,feedin,feedout,-1);
                       
            %Generate the beam response
            y_ddot=lsim(this.sys_fb,this.sig_disturb,this.time,[],'zoh');
            this.y1_ddot=y_ddot(:,1);
            this.y2_ddot=y_ddot(:,2);
            this.y3_ddot=y_ddot(:,3);
            
            %Compute the Agent input
            this.rms_y1_ddot=rms(this.y1_ddot);
            this.rms_y2_ddot=rms(this.y2_ddot);
            this.rms_y3_ddot=rms(this.y3_ddot);

            Obs(1) = this.rms_y1_ddot;
            Obs(2) = this.rms_y2_ddot;
            Obs(3) = this.rms_y3_ddot;
            
             if isnan(Obs(1))
                  Obs(1)=this.rms_y1_ddot_ref;
             end
             if isnan(Obs(2))
                  Obs(2)=this.rms_y2_ddot_ref;
             end
             if isnan(Obs(3))
                  Obs(3)=this.rms_y3_ddot_ref;
             end
             if Obs(1)>10
                  Obs(1)=this.rms_y1_ddot_ref;
             end
             if Obs(2)>10
                  Obs(2)=this.rms_y2_ddot_ref;
             end
             if Obs(3)>10
                  Obs(2)=this.rms_y3_ddot_ref;
             end

            x=[this.rms_y1_ddot_ref;this.rms_y2_ddot_ref;this.rms_y3_ddot_ref]; 
            
            x1=[Obs(1);Obs(2);Obs(3)];
            Observation=x1./10;%2*(x1-min(x))/(max(x)-min(x))-1;%
                       
            % Get reward
            if this.rwd_type =='rwd_freq'
                Reward = getReward_freq(this);
            end 
            if this.rwd_type =='rwd_time'
                Reward = getReward_rms(this);
            end 

            Reward = stability(this,Reward)
 
            if Reward<-1
                Reward=-1
            end
            if Reward>100
                Reward=-1
            end

            % Update system states
            this.State(1) = Observation(1);
            this.State(2) = Observation(2);
            this.State(3) = Observation(3);
            
            %Episode ending condition 
            IsDone = true;
                                  
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %notifyEnvUpdated(this);
            %varargout = plot(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            
            %            
            y_ddot_ref=lsim(this.Sys_mimo,this.sig_disturb,this.time,[],'zoh');

            this.y1_ddot_ref=y_ddot_ref(:,1);
            this.y2_ddot_ref=y_ddot_ref(:,2);
            this.y3_ddot_ref=y_ddot_ref(:,3);
            
            this.rms_y1_ddot_ref=rms(this.y1_ddot_ref);
            this.rms_y2_ddot_ref=rms(this.y2_ddot_ref);
            this.rms_y3_ddot_ref=rms(this.y3_ddot_ref);
            
            x=[this.rms_y1_ddot_ref;this.rms_y2_ddot_ref;this.rms_y3_ddot_ref]; 

            InitialObservation=x./10;%2*(x-min(x))/(max(x)-min(x))-1;%
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %notifyEnvUpdated(this);
            
        end
    end

    methods (Access = protected)
        function envUpdatedCallback(this)
            if ~isempty(this.Figure) && isvalid(this.Figure)
                % Set visualization figure as the current figure
            end
            drawnow();
        end
    end
   

    

    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Helper methods to create the environment
        % (optional) Visualization method
                  
%         function set.Ts(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','Ts');
%             this.Ts = val;
%         end
        
function Reward = getReward_rms(this)
              
            Reward = (this.rms_y1_ddot_ref/this.rms_y1_ddot+this.rms_y2_ddot_ref/this.rms_y2_ddot+this.rms_y3_ddot_ref/this.rms_y3_ddot)
          
        end
        function Reward = getReward_freq(this)
            
            %w = [80:0.1:1000]*2*pi;
            w = [350:0.01:388]*2*pi;
           % w = [300:0.01:388]*2*pi;
            %w = [220:0.01:388]*2*pi;
            Reward = sum(trapz(bode(this.Sys_mimo(1,1),w),3),'all')./sum(trapz(bode(this.sys_fb(1,1),w),3),'all') ...
                    +sum(trapz(bode(this.Sys_mimo(2,2),w),3),'all')./sum(trapz(bode(this.sys_fb(2,2),w),3),'all')...
                    +sum(trapz(bode(this.Sys_mimo(3,3),w),3),'all')./sum(trapz(bode(this.sys_fb(3,3),w),3),'all')
           
        end
   

        function Reward = stability(this,Reward)

           feedin=[2 3];
            feedout=[2 3];
            sys_fb1=feedback(this.Sys_mimo,[this.H(2,2) 0; 0 this.H(3,3)],feedin,feedout,-1);
%             cond_A = cond(sys_fb1.A);
%             cond_B = cond(sys_fb1.B);
%             cond_C = cond(sys_fb1.C);
%             
%             if ((cond_A < 10^17) && (cond_B < 10^17) && (cond_C < 10^17))
                [Gm1,Pm1,Wcg1,Wcp1,IsStable]=margin(sys_fb1(1,1)*this.H(1,1));            
%                     if (IsStable==0)
%                         Gm1=-10;
%                         Wcg1=1000;
%                     end
                feedin=[1 3];
                feedout=[1 3];
                
                sys_fb2=feedback(this.Sys_mimo,[this.H(1,1) 0; 0 this.H(3,3)],feedin,feedout,-1);
%                 cond_A = cond(sys_fb2.A);
%                 cond_B = cond(sys_fb2.B);
%                 cond_C = cond(sys_fb2.C);
% 
%                 
%                 if ((cond_A < 10^17) && (cond_B < 10^17) && (cond_C < 10^17)) 
                    [Gm2,Pm2,Wcg2,Wcp2,IsStable]=margin(sys_fb2(2,2)*this.H(2,2));
%                         if (IsStable==0)
%                             Gm2=-10;
%                             Wcg2=1000;
%                         end
            
                    feedin=[1 2];
                    feedout=[1 2];
                    sys_fb3=feedback(this.Sys_mimo,[this.H(1,1) 0; 0 this.H(2,2)],feedin,feedout,-1);
%                     cond_A = cond(sys_fb3.A);
%                     cond_B = cond(sys_fb3.B);
%                     cond_C = cond(sys_fb3.C);
%                     
%                     if ( (cond_A < 10^17) && (cond_B < 10^17) && (cond_C < 10^17) )
                        [Gm3,Pm3,Wcg3,Wcp3,IsStable]=margin(sys_fb3(3,3)*this.H(3,3));
%                             if (IsStable==0)
%                                 Gm3=-10;
%                                 Wcg3=1000;
%                             end
%                     else 
%                         Gm3=-10;
%                         Wcg3=1000;
%                     end
%                 else
%                     Gm2=-10;
%                     Wcg2=1000;
%                 end
%             else
%                 Gm1=-10;
%                 Wcg1=1000;
%             end
            Gm_dB=20*log10([Gm1 Gm2 Gm3]);
            this.Gm=Gm_dB;
            this.Pm=[Pm1 Pm2 Pm3];
            Gmref=10;  
            Pmref=30;
                        
            if  ~IsStable || ((Gm_dB(1)<Gmref && Wcg1>10) || (Gm_dB(2)<Gmref && Wcg2>10) || (Gm_dB(3)<Gmref && Wcg3>10) || Pm1<Pmref && Wcp1>10 || (Pm2<Pmref && Wcp2>10) || (Pm3<Pmref && Wcp3>10) || (this.rms_y2_ddot>10) || (isnan(this.rms_y2_ddot)) || (this.rms_y2_ddot == Inf))  
               disp('not')
                 
               corr1=Gm_dB(Gm_dB<10) 
               corr1=corr1(corr1>0)
               corr2=Gm_dB(Gm_dB<0)
               corr2=corr2(corr2>-10)

               if isempty(corr1)
                   corr1=0;
               end
               
               %corr=corr(corr>0)
                 %Reward = -abs(20*log10(Reward))+(Gm_dB(1)/10+Gm_dB(2)/10+Gm_dB(3)/10)%-20*log10(3);
                  
                  if IsStable 
                    disp('IsStable')
                    Reward = 20*log10(Reward)*(abs(prod(corr1/10)))
                  elseif isempty(corr2)
                     Reward = -1
                  else
                    Reward = -(abs(prod(corr2/10)))%-20*log10(3);
                  end
% 
% 
%               if (Reward > 3)
%                     Reward = -20*log10(Reward-2.9)-20;%-20*log10(2*Reward);
%                else
%                     Reward = 20*log10(Reward)-10;%-(3*Reward-9).^2;%20*log10(1/18*Reward);
%                end
%                if (isnan(this.rms_y2_ddot))
%                     Reward = Reward - 1 ;
%                end
%             elseif ((~isnan(this.rms_y2_ddot)) || (this.rms_y2_ddot ~= Inf)) && (Reward > 0)
%                Reward = 10 + Reward
            else
                disp('else')
                Reward = 20*log10(Reward)%+Gm_dB(1)/10*Gm_dB(2)/10*Gm_dB(3)/10;%-20*log10(3);
%                 if (Reward > 3)
%                     Reward = 20*log10(Reward-2.9)+20;%(3*Reward-9).^2;%20*log10(1/6*Reward-2/6);
%                 else
%                     Reward = 20*log10(Reward)-10;%20*log10(1/18*Reward);
%                 end        
            end
             
            % Reward = (this.rms_y1_ddot_ref/this.rms_y1_ddot+this.rms_y2_ddot_ref/this.rms_y2_ddot+this.rms_y3_ddot_ref/this.rms_y3_ddot);
          
            if isnan(Reward)
                 Reward = this.Rmin;
            end
            if abs(Reward)==Inf
                 Reward = this.Rmin;
            end
             if Reward < this.Rmin
                 this.Rmin = Reward ;
             end  

             if Reward > this.Rmax
                 this.Rmax = Reward ;
             end 

             %Normalisation du Rwd entre -1 et 1
%              if (this.norm == 1)
%                 Reward=atan(Reward)*2/pi;
%              end

             if (this.norm == 1)
                if Reward<0 
                    Reward=-Reward/this.Rmin; 
                end
                if Reward>0 
                    Reward=Reward%/this.Rmax*10; 
                end
                %Reward=Reward/2-1/2;
             end
             
        end
% figure
% hold on
% plot([0:0.1:3],20*log10([0:0.1:3]*1/18));
% plot([3:0.1:6],20*log10(1/6*[3:0.1:6]-1/3));
% plot([3:0.1:6],-20*log10(2*[3:0.1:6]));

% figure
% hold on
% plot([0:0.1:3],20*log10([0:0.1:3]*1/10));
% plot([3:0.1:6],20*log10(3*[3:0.1:6]-2.9*3));
% plot([3:0.1:6],-20*log10(35*[3:0.1:6]-35*2.9));
% figure
% hold on
% plot([0:0.1:3],20*log10([0:0.1:3]*1/10));
% plot([3:0.1:6],20*log10(3*[3:0.1:6]-2.9*3));
% plot([0:0.1:6],-(3*[0:0.1:6]-9).^2-11);

% figure
% hold on
% plot([0:0.1:3],(20*log10([0:0.1:3])-10));
% plot([3:0.1:6],((3*[3:0.1:6]-9).^2));
% plot([3:0.1:6],(-20*log10([3:0.1:6]-2.9)-20));
% 
% figure
% hold on
% plot([0:0.1:3],atan(20*log10([0:0.1:3])-10)*2/pi);
% plot([3:0.1:6],atan((3*[3:0.1:6]-9).^2)*2/pi);
% plot([3:0.1:6],atan(-20*log10([3:0.1:6]-2.9)-20)*2/pi);
    end
end